package fr.gharrowbm.springapitestingnosecurity.payloads;

import fr.gharrowbm.springapitestingnosecurity.entities.AppUserRole;

public record RegisterRequest(String email, String password, AppUserRole userRole) {
}
