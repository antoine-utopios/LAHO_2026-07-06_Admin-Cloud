package fr.gharrowbm.springapitestingnosecurity.services;

import fr.gharrowbm.springapitestingnosecurity.entities.AppUser;
import fr.gharrowbm.springapitestingnosecurity.exceptions.EmailNotFoundException;
import fr.gharrowbm.springapitestingnosecurity.payloads.LoginRequest;
import fr.gharrowbm.springapitestingnosecurity.payloads.LoginResponse;
import fr.gharrowbm.springapitestingnosecurity.payloads.RegisterRequest;
import fr.gharrowbm.springapitestingnosecurity.repositories.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AppUserRepository appUserRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public boolean register(RegisterRequest request) throws Exception {
        appUserRepository.save(AppUser.builder().email(request.email()).password(passwordEncoder.encode(request.password())).role(request.userRole()).build());

        return true;
    }

    public LoginResponse login(LoginRequest request) throws Exception {
        AppUser userFound = appUserRepository.findByEmail(request.email()).orElseThrow(() -> new EmailNotFoundException(request.email()));

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(userFound.getUsername(), request.password())
        );

        if(authentication.isAuthenticated()) {
            String token = jwtService.generateToken(authentication);
            return new LoginResponse(token);
        }

        return null;
    }

}
