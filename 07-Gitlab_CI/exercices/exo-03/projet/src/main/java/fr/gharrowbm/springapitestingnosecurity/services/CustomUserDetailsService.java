package fr.gharrowbm.springapitestingnosecurity.services;

import fr.gharrowbm.springapitestingnosecurity.exceptions.EmailNotFoundException;
import fr.gharrowbm.springapitestingnosecurity.repositories.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
    private final AppUserRepository appUserRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws EmailNotFoundException {
        return appUserRepository.findByEmail(username).orElseThrow(() -> new EmailNotFoundException(username));
    }
}
