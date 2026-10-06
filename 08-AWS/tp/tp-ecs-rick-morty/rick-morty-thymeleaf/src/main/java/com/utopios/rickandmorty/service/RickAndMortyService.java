package com.utopios.rickandmorty.service;

import com.utopios.rickandmorty.model.ApiPage;
import com.utopios.rickandmorty.model.Character;
import com.utopios.rickandmorty.model.Episode;
import com.utopios.rickandmorty.model.Location;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

/**
 * Service consommant l'API publique Rick and Morty (https://rickandmortyapi.com/api).
 * <p>
 * Endpoints exploités :
 * <ul>
 *   <li>GET /character — liste paginée + filtres (name, status, species, gender, type)</li>
 *   <li>GET /character/{id} — un personnage</li>
 *   <li>GET /character/{id1,id2,id3} — plusieurs personnages</li>
 *   <li>GET /location — liste paginée + filtres (name, type, dimension)</li>
 *   <li>GET /location/{id} — une location</li>
 *   <li>GET /episode — liste paginée + filtres (name, episode)</li>
 *   <li>GET /episode/{id} — un épisode</li>
 * </ul>
 */
@Service
public class RickAndMortyService {

    private static final Logger log = LoggerFactory.getLogger(RickAndMortyService.class);

    private static final ParameterizedTypeReference<ApiPage<Character>> CHARACTER_PAGE_TYPE =
            new ParameterizedTypeReference<>() {};
    private static final ParameterizedTypeReference<ApiPage<Location>> LOCATION_PAGE_TYPE =
            new ParameterizedTypeReference<>() {};
    private static final ParameterizedTypeReference<ApiPage<Episode>> EPISODE_PAGE_TYPE =
            new ParameterizedTypeReference<>() {};

    private final WebClient webClient;

    public RickAndMortyService(WebClient rickAndMortyWebClient) {
        this.webClient = rickAndMortyWebClient;
    }

    // ============================================================
    //                       CHARACTERS
    // ============================================================

    /**
     * Liste paginée des personnages avec filtres optionnels.
     * Tous les filtres sont combinables côté API.
     */
    public ApiPage<Character> findCharacters(int page, String name, String status,
                                              String species, String gender, String type) {
        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/character")
                        .queryParam("page", page)
                        .queryParamIfPresent("name", optional(name))
                        .queryParamIfPresent("status", optional(status))
                        .queryParamIfPresent("species", optional(species))
                        .queryParamIfPresent("gender", optional(gender))
                        .queryParamIfPresent("type", optional(type))
                        .build())
                .retrieve()
                .bodyToMono(CHARACTER_PAGE_TYPE)
                .doOnError(e -> log.error("API call /character failed: {}", e.toString()))
                .onErrorResume(WebClientResponseException.NotFound.class,
                        e -> Mono.just(emptyPage()))
                .block();
    }

    public Character findCharacterById(Long id) {
        return webClient.get()
                .uri("/character/{id}", id)
                .retrieve()
                .bodyToMono(Character.class)
                .doOnError(e -> log.error("API call /character/{} failed: {}", id, e.toString()))
                .block();
    }

    /**
     * Récupère plusieurs personnages en un seul appel via /character/1,2,3.
     * Utilisé pour afficher les résidents d'une location ou les acteurs d'un épisode.
     */
    public List<Character> findCharactersByIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Collections.emptyList();
        }
        if (ids.size() == 1) {
            // L'API retourne un objet seul, pas un array, pour un seul ID
            Character c = findCharacterById(ids.get(0));
            return c != null ? List.of(c) : Collections.emptyList();
        }
        String joined = ids.stream().map(String::valueOf).reduce((a, b) -> a + "," + b).orElse("");
        return webClient.get()
                .uri("/character/{ids}", joined)
                .retrieve()
                .bodyToFlux(Character.class)
                .collectList()
                .onErrorReturn(Collections.emptyList())
                .block();
    }

    // ============================================================
    //                       LOCATIONS
    // ============================================================

    public ApiPage<Location> findLocations(int page, String name, String type, String dimension) {
        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/location")
                        .queryParam("page", page)
                        .queryParamIfPresent("name", optional(name))
                        .queryParamIfPresent("type", optional(type))
                        .queryParamIfPresent("dimension", optional(dimension))
                        .build())
                .retrieve()
                .bodyToMono(LOCATION_PAGE_TYPE)
                .doOnError(e -> log.error("API call /location failed: {}", e.toString()))
                .onErrorResume(WebClientResponseException.NotFound.class,
                        e -> Mono.just(emptyPage()))
                .block();
    }

    public Location findLocationById(Long id) {
        return webClient.get()
                .uri("/location/{id}", id)
                .retrieve()
                .bodyToMono(Location.class)
                .block();
    }

    // ============================================================
    //                       EPISODES
    // ============================================================

    public ApiPage<Episode> findEpisodes(int page, String name, String episodeCode) {
        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/episode")
                        .queryParam("page", page)
                        .queryParamIfPresent("name", optional(name))
                        .queryParamIfPresent("episode", optional(episodeCode))
                        .build())
                .retrieve()
                .bodyToMono(EPISODE_PAGE_TYPE)
                .doOnError(e -> log.error("API call /episode failed: {}", e.toString()))
                .onErrorResume(WebClientResponseException.NotFound.class,
                        e -> Mono.just(emptyPage()))
                .block();
    }

    public Episode findEpisodeById(Long id) {
        return webClient.get()
                .uri("/episode/{id}", id)
                .retrieve()
                .bodyToMono(Episode.class)
                .block();
    }

    // ============================================================
    //                       UTILS
    // ============================================================

    /**
     * Extrait les IDs depuis une liste d'URLs API (format /api/character/N).
     */
    public static List<Long> extractIds(List<String> urls) {
        if (urls == null) return Collections.emptyList();
        return urls.stream()
                .map(RickAndMortyService::extractId)
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    private static Long extractId(String url) {
        if (url == null || url.isBlank()) return null;
        try {
            String[] parts = url.split("/");
            return Long.parseLong(parts[parts.length - 1]);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static Optional<String> optional(String s) {
        return (s == null || s.isBlank()) ? Optional.empty() : Optional.of(s.trim());
    }

    private static <T> ApiPage<T> emptyPage() {
        return new ApiPage<>(
                new com.utopios.rickandmorty.model.PageInfo(0, 0, null, null),
                Collections.emptyList()
        );
    }
}
