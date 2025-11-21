
IMAGE := $(strip gocontainer:latest)
NAME := $(strip gocontainer)
DOCKERFILE := $(strip .devcontainer/Dockerfile)
PWD := $(strip $(shell pwd))
DEVPOD := $(strip $(shell command -v devpod 2>/dev/null || true))
HAS_DEVPOD := $(if $(DEVPOD),1,0)

.PHONY: build up ssh stop delete

build:
	@if [ "$(HAS_DEVPOD)" = "1" ]; then \
		echo "devpod detected; skip docker build (use 'devpod up' to create the pod)"; \
	else \
		docker build -f $(DOCKERFILE) -t $(IMAGE) .; \
	fi

up:
	@if [ "$(HAS_DEVPOD)" = "1" ]; then \
		devpod up . --ide none; \
	else \
		$(MAKE) build; \
		docker run -d --name $(NAME) -v "$(PWD):/workspace" -w /workspace $(IMAGE) tail -f /dev/null; \
	fi

ssh:
	@if [ "$(HAS_DEVPOD)" = "1" ]; then \
		devpod ssh $(NAME); \
	else \
		docker exec -it --user vscode $(NAME) zsh; \
	fi

stop:
	@if [ "$(HAS_DEVPOD)" = "1" ]; then \
		devpod stop $(NAME) || true; \
	else \
		docker stop $(NAME) || true; \
	fi

delete:
	@if [ "$(HAS_DEVPOD)" = "1" ]; then \
		devpod delete $(NAME) || true; \
	else \
		docker rm -f $(NAME) || true; \
		docker image rm $(IMAGE) || true; \
	fi
