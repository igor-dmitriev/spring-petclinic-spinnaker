package org.springframework.samples.petclinic.security;

import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Collections;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.SignatureException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class TokenAuthentication {

  private final String secretKey;
  private final long expirationTimeSeconds;
  private final String tokenPrefix;

  public TokenAuthentication(String secretKey, long expirationTimeSeconds, String tokenPrefix) {
    this.secretKey = secretKey;
    this.expirationTimeSeconds = expirationTimeSeconds;
    this.tokenPrefix = tokenPrefix;
  }

  void addAuthentication(HttpServletResponse res, String username) throws IOException {
    String jwtToken = Jwts.builder()
        .setSubject(username)
        .setExpiration(Date.from(LocalDateTime.now().plusSeconds(expirationTimeSeconds).atZone(ZoneOffset.UTC).toInstant()))
        .signWith(SignatureAlgorithm.HS512, secretKey)
        .compact();
    res.addHeader(HttpHeaders.AUTHORIZATION, tokenPrefix + " " + jwtToken);
    res.getWriter().write("{\"token\":\"" + jwtToken + "\"}");
  }

  Authentication getAuthentication(HttpServletRequest request) {
    String token = request.getHeader(HttpHeaders.AUTHORIZATION);
    if (token == null) {
      return null;
    }

    try {
      String user = Jwts.parser()
          .setSigningKey(secretKey)
          .parseClaimsJws(token.replace(tokenPrefix, ""))
          .getBody()
          .getSubject();

      return user != null ?
          new UsernamePasswordAuthenticationToken(user, null, Collections.emptyList()) :
          null;
    } catch (ExpiredJwtException e) {
      return null;
    } catch (SignatureException e) {
      log.info("JWT signature does not match locally computed signature");
      return null;
    }
  }
}