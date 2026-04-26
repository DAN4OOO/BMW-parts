package com.bmwparts.controller;

import com.bmwparts.dto.VehicleInfo;
import com.bmwparts.model.SearchHistory;
import com.bmwparts.model.User;
import com.bmwparts.model.UserGarage;
import com.bmwparts.repository.GarageRepository;
import com.bmwparts.repository.SearchHistoryRepository;
import com.bmwparts.service.CatalogService;
import com.bmwparts.service.UserService;
import com.bmwparts.service.VinDecodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriUtils;
import java.nio.charset.StandardCharsets;

@Controller
@RequiredArgsConstructor
public class MainController {

    private final VinDecodeService vinDecodeService;
    private final CatalogService catalogService;
    private final UserService userService;
    private final GarageRepository garageRepository;
    private final SearchHistoryRepository searchHistoryRepository;

    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserDetails)) {
            return null;
        }
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        return userService.findByEmail(email).map(User::getId).orElse(null);
    }

    private String getCurrentUserName() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserDetails)) {
            return null;
        }
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        return userService.findByEmail(email)
                .map(User::getFullName)
                .orElse(email.split("@")[0]);
    }

    @ModelAttribute("currentUser")
    public User addCurrentUserToModel() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserDetails)) {
            return null;
        }
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        return userService.findByEmail(email).orElse(null);
    }

    @ModelAttribute("currentUserName")
    public String addCurrentUserNameToModel() {
        return getCurrentUserName();
    }

    @GetMapping("/")
    public String home(@RequestParam(value = "error", required = false) String error, Model model) {
        if (error != null) {
            model.addAttribute("error", error);
        }
        return "index";
    }

    @PostMapping("/decode")
    public String decodeVin(@RequestParam("vin") String vin) {
        VehicleInfo info = vinDecodeService.decodeVin(vin);

        if (info.isValid()) {
            Long userId = getCurrentUserId();
            if (userId != null) {
                SearchHistory history = SearchHistory.builder()
                        .user(User.builder().id(userId).build())
                        .vin(vin.toUpperCase())
                        .build();
                searchHistoryRepository.save(history);
            }
            return "redirect:/groups?vin=" + UriUtils.encode(vin, StandardCharsets.UTF_8);
        }
        return "redirect:/?error=" + UriUtils.encode(info.getErrorMessage(), StandardCharsets.UTF_8);
    }

    @GetMapping("/groups")
    public String groups(@RequestParam(required = false) String vin, Model model) {
        VehicleInfo info = null;
        if (vin != null && !vin.isBlank()) {
            info = vinDecodeService.decodeVin(vin);
            Long userId = getCurrentUserId();
            if (userId != null && info.isValid()) {
                boolean inGarage = garageRepository.existsByUser_IdAndVin(userId, vin.toUpperCase());
                model.addAttribute("inGarage", inGarage);
            }
        }
        model.addAttribute("vehicle", info);
        model.addAttribute("groups", catalogService.getAllGroups());
        return "groups";
    }

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

    @GetMapping("/login")
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "success", required = false) String success,
                            Model model) {
        model.addAttribute("loginError", error != null);
        model.addAttribute("registrationSuccess", success != null);
        return "login";
    }

    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    @PostMapping("/do-register")
    public String handleRegistration(@RequestParam String email,
                                     @RequestParam String password,
                                     @RequestParam String fullName,
                                     Model model) {
        try {
            userService.register(email, password, fullName);
            return "redirect:/login?success";
        } catch (IllegalArgumentException e) {
            model.addAttribute("registrationError", e.getMessage());
            return "register";
        }
    }

    @GetMapping("/garage")
    public String garagePage(Model model) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return "redirect:/login";
        }
        var garageItems = garageRepository.findByUser_Id(userId);
        model.addAttribute("garageItems", garageItems);
        return "garage";
    }

    @PostMapping("/api/garage/add")
    public String addToGarage(@RequestParam String vin) {
        Long userId = getCurrentUserId();
        if (userId != null) {
            boolean exists = garageRepository.existsByUser_IdAndVin(userId, vin.toUpperCase());
            if (!exists) {
                UserGarage item = UserGarage.builder()
                        .user(User.builder().id(userId).build())
                        .vin(vin.toUpperCase())
                        .build();
                garageRepository.save(item);
            }
        }
        return "redirect:/groups?vin=" + vin;
    }

    @PostMapping("/api/garage/remove")
    public String removeFromGarage(@RequestParam String vin) {
        Long userId = getCurrentUserId();
        if (userId != null) {
            garageRepository.findByUser_IdAndVin(userId, vin.toUpperCase())
                    .ifPresent(garageRepository::delete);
        }
        return "redirect:/garage";
    }

    @GetMapping("/history")
    public String historyPage(Model model) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return "redirect:/login";
        }
        var history = searchHistoryRepository.findByUser_IdOrderBySearchedAtDesc(userId);
        model.addAttribute("searchHistory", history);
        return "history";
    }

    @PostMapping("/api/history/clear")
    public String clearHistoryEntry(@RequestParam Long id) {
        Long userId = getCurrentUserId();
        if (userId != null) {
            searchHistoryRepository.findById(id)
                    .filter(entry -> entry.getUser().getId().equals(userId))
                    .ifPresent(searchHistoryRepository::delete);
        }
        return "redirect:/history";
    }

    @PostMapping("/api/history/clear-all")
    public String clearAllHistory() {
        Long userId = getCurrentUserId();
        if (userId != null) {
            var entries = searchHistoryRepository.findByUser_IdOrderBySearchedAtDesc(userId);
            searchHistoryRepository.deleteAll(entries);
        }
        return "redirect:/history";
    }

    @GetMapping("/profile")
    public String profilePage(Model model) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return "redirect:/login";
        }
        long garageCount = garageRepository.countByUser_Id(userId);
        long historyCount = searchHistoryRepository.countByUser_Id(userId);
        model.addAttribute("garageCount", garageCount);
        model.addAttribute("historyCount", historyCount);
        return "profile";
    }
}
