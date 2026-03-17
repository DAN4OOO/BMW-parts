package com.bmwparts.controller;

import com.bmwparts.dto.VehicleInfo;
import com.bmwparts.service.CatalogService;
import com.bmwparts.service.VinDecodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
public class MainController {

    private final VinDecodeService vinDecodeService;
    private final CatalogService catalogService;

    // ── Home / VIN entry ───────────────────────────────────────
    @GetMapping("/")
    public String home() {
        return "index";
    }

    // ── VIN Decode POST ────────────────────────────────────────
    @PostMapping("/decode")
    public String decodeVin(@RequestParam("vin") String vin, Model model) {
        VehicleInfo info = vinDecodeService.decodeVin(vin);
        model.addAttribute("vehicle", info);

        if (info.isValid()) {
            model.addAttribute("groups", catalogService.getAllGroups());
            return "groups";          // show part groups page
        }
        model.addAttribute("error", info.getErrorMessage());
        return "index";              // back to home with error
    }

    // ── Part Groups page (GET, after session stored) ───────────
    @GetMapping("/groups")
    public String groups(@RequestParam(required = false) String vin, Model model) {
        VehicleInfo info = null;
        if (vin != null && !vin.isBlank()) {
            info = vinDecodeService.decodeVin(vin);
        }
        model.addAttribute("vehicle", info);
        model.addAttribute("groups", catalogService.getAllGroups());
        return "groups";
    }

    // ── Component list for a group ─────────────────────────────
    @GetMapping("/group/{groupCode}")
    public String groupComponents(@PathVariable String groupCode,
                                  @RequestParam(required = false) String vin,
                                  Model model) {
        var group = catalogService.getGroupByCode(groupCode);
        if (group.isEmpty()) return "redirect:/groups";

        model.addAttribute("group", group.get());
        model.addAttribute("components", catalogService.getComponentsByGroup(groupCode));
        model.addAttribute("vin", vin);
        return "components";
    }

    // ── Component detail / parts diagram ──────────────────────
    @GetMapping("/component/{componentCode}")
    public String componentDetail(@PathVariable String componentCode,
                                  @RequestParam(required = false) String vin,
                                  Model model) {
        var component = catalogService.getComponentDetail(componentCode);
        if (component.isEmpty()) return "redirect:/groups";

        model.addAttribute("component", component.get());
        model.addAttribute("vin", vin);
        return "part-detail";
    }
}
