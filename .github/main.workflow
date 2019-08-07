workflow "Build & Push Containers" {
  on = "push"
  resolves = ["Action for unbound Docker", "Action for haproxy Docker", "Action for dnscrypt-wrapper Docker", "Action for m13253-doh Docker"]
}

action "Docker Registry" {
  uses = "actions/docker/login@86ff551d26008267bb89ac11198ba7f1d807b699"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "nsd filter" {
  uses = "actions/bin/filter@master"
  args = "issue_comment .*nsd.*"
}

action "Action for nsd Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Registry", "nsd filter"]
  args = "docker build -t publicarray/nsd nsd && docker push publicarray/nsd"
  secrets = ["DOCKER_PASSWORD", "DOCKER_USERNAME"]
}

action "unbound filter" {
  uses = "actions/bin/filter@master"
  args = "issue_comment .*unbound.*"
}

action "Action for unbound Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Registry", "unbound filter"]
  args = "docker build -t publicarray/unbound unbound && docker push publicarray/unbound"
}

action "haproxy filter" {
  uses = "actions/bin/filter@master"
  args = "issue_comment .*haproxy.*"
}

action "Action for haproxy Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Registry", "haproxy filter"]
  args = "docker build -t publicarray/haproxy haproxy && docker push publicarray/haproxy"
}

action "dnscrypt-wrapper filter" {
  uses = "actions/bin/filter@master"
  args = "issue_comment .*dnscrypt.*"
}

action "Action for dnscrypt-wrapper Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Registry", "dnscrypt-wrapper filter"]
  args = "docker build -t publicarray/dnscrypt-wrapper dnscrypt-wrapper && docker push publicarray/dnscrypt-wrapper"
}

action "m13253-doh filter" {
  uses = "actions/bin/filter@master"
  args = "issue_comment .*m13253.*"
}

action "Action for m13253-doh Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Registry", "m13253-doh filter"]
  args = "docker build -t publicarray/m13253-doh m13253-doh && docker push publicarray/m13253-doh"
}
