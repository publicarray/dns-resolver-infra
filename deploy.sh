#!/bin/sh

# Cert issuance + renewal is handled inside docker-compose by the `acme`
# (one-shot issuer) and `acme-daemon` (renewal) services, so bringing the whole
# stack up — including TLS certs — is just `docker compose up`.
#
# CF credentials + DOMAIN come from .env (read automatically by compose).
# See .env.example.

set +x

# docker stack deploy dns --compose-file docker-stack.yml
docker compose pull
docker compose up -d --remove-orphans
