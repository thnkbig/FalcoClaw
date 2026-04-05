BINARY    := falcoclaw
VERSION   := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT    := $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
DATE      := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS   := -s -w \
             -X github.com/thnkbig/falcoclaw/cmd.Version=$(VERSION) \
             -X github.com/thnkbig/falcoclaw/cmd.GitCommit=$(COMMIT) \
             -X github.com/thnkbig/falcoclaw/cmd.BuildDate=$(DATE)

.PHONY: all build install clean test lint lint-fix ci-check ci-check-fast check docker service-install service-uninstall

all: build

build:
	CGO_ENABLED=0 go build -ldflags "$(LDFLAGS)" -o bin/$(BINARY) .

install: build
	install -m 755 bin/$(BINARY) /usr/local/bin/$(BINARY)
	mkdir -p /etc/falcoclaw /var/log/falcoclaw /var/quarantine/falcoclaw
	test -f /etc/falcoclaw/config.yaml || cp config.yaml /etc/falcoclaw/config.yaml
	test -f /etc/falcoclaw/rules.yaml || cp rules/responses.yaml /etc/falcoclaw/rules.yaml

uninstall:
	rm -f /usr/local/bin/$(BINARY)

test:
	go test ./... -v -count=1

# Lint: fix formatting issues in-place
lint-fix:
	go mod tidy
	go fmt ./...

# Lint: check formatting (CI-style, no auto-fix)
lint:
	@echo "Running go vet..."
	@go vet ./... || { echo "go vet failed"; exit 1; }
	@echo "Checking formatting..."
	@unformatted=$$(gofmt -l .); \
	if [ -n "$$unformatted" ]; then \
		echo "Unformatted files:"; echo "$$unformatted"; \
		echo "Run 'make lint-fix' to auto-fix"; \
		exit 1; \
	fi
	@echo "Checking go.sum is tracked..."
	@if ! git ls-files --error-unmatch go.sum >/dev/null 2>&1; then \
		echo "go.sum is not tracked in git — run 'git add go.sum && git commit'"; \
		exit 1; \
	fi
	@echo "All lint checks passed."

# Fast CI check: skip go mod tidy (assumes dependencies are current)
ci-check-fast: build
	@echo "Running go vet..."
	@go vet ./... || { echo "go vet failed"; exit 1; }
	@echo "Checking formatting..."
	@unformatted=$$(gofmt -l .); \
	if [ -n "$$unformatted" ]; then \
		echo "Unformatted files:"; echo "$$unformatted"; exit 1; \
	fi
	@echo "ci-check-fast passed."

# Full CI check (what GitHub Actions runs) — use this in pre-commit
ci-check: lint

check: build
	bin/$(BINARY) check --rules rules/responses.yaml

docker:
	docker build -t falcoclaw:$(VERSION) -t falcoclaw:latest .

clean:
	rm -rf bin/

service-install: install
	mkdir -p /etc/systemd/system
	printf '%s\n' '[Unit]' 'Description=FalcoClaw Response Engine' 'After=network.target falco.service' 'Wants=falco.service' '' '[Service]' 'Type=simple' 'Environment="TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}"' 'Environment="TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}"' 'Environment="TELEGRAM_SECURITY_TOPIC_ID=${TELEGRAM_SECURITY_TOPIC_ID}"' 'ExecStart=/usr/local/bin/falcoclaw server -c /etc/falcoclaw/config.yaml -r /etc/falcoclaw/rules.yaml' 'Restart=always' 'RestartSec=5' 'StandardOutput=journal' 'StandardError=journal' '' '[Install]' 'WantedBy=multi-user.target' > /etc/systemd/system/falcoclaw.service
	systemctl daemon-reload
	systemctl enable falcoclaw
	systemctl start falcoclaw

service-uninstall:
	systemctl stop falcoclaw || true
	systemctl disable falcoclaw || true
	rm -f /etc/systemd/system/falcoclaw.service
	systemctl daemon-reload
