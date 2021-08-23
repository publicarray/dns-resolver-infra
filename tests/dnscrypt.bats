#!/usr/bin/env bats

# https://dnscrypt.info/stamps/

@test "139.99.222.72 dnscrypt" {
    run doggo example.com @sdns://AQcAAAAAAAAAEjEzOS45OS4yMjIuNzI6ODQ0MyDR7bj6zoAmbRaE1B8qTkCL_O84QCDMYPUgXZy5FRqUYRsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
    [ "$status" -eq 0 ]
}
@test "139.99.222.72 DNS-over-HTTPS" {
    run doggo example.com @sdns://AgcAAAAAAAAADTEzOS45OS4yMjIuNzKgPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDggMob_ZaZfrzIIXuoTiMNzi6fjeHPJBszjxKKLTMKliYgRZG9oLTIuc2VieS5pbzo0NDMKL2Rucy1xdWVyeQ
    [ "$status" -eq 0 ]
}

@test "45.76.113.31 dnscrypt" {
    run doggo example.com @sdns://AQcAAAAAAAAADDQ1Ljc2LjExMy4zMSAIVGh4i6eKXqlF6o9Fg92cgD2WcDvKQJ7v_Wq4XrQsVhsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 DNS-over-HTTPS" {
    run doggo example.com @sdns://AgcAAAAAAAAADDQ1Ljc2LjExMy4zMaA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OCAyhv9lpl-vMghe6hOIw3OLp-N4c8kGzOPEootMwqWJiBBkb2guc2VieS5pbzo4NDQzCi9kbnMtcXVlcnk
    [ "$status" -eq 0 ]
}
