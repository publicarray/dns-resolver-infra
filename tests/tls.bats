#!/usr/bin/env bats

@test "139.99.222.72 TLS 1.3 support DNS-over-TLS" {
  result=$(echo "Q" | openssl s_client -connect 139.99.222.72:853)
  [[ "$result" =~ "TLSv1.3" ]]
}

@test "139.99.222.72 TLS 1.3 support DNS-over-HTTPS" {
  result=$(echo "Q" | openssl s_client -connect 139.99.222.72:443)
  [[ "$result" =~ "TLSv1.3" ]]
}

@test "45.76.113.31 TLS 1.3 support DNS-over-TLS" {
  result=$(echo "Q" | openssl s_client -connect 45.76.113.31:853)
  [[ "$result" =~ "TLSv1.3" ]]
}

@test "45.76.113.31 TLS 1.3 support DNS-over-HTTPS" {
  result=$(echo "Q" | openssl s_client -connect 45.76.113.31:8443)
  [[ "$result" =~ "TLSv1.3" ]]
}
