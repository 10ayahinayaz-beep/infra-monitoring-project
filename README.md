## Безопасная передача проекта на удалённый сервер (SSH / SCP)

### 1. Генерация SSH-ключей

```bash
ssh-keygen -t ed25519 -C "deploy@infra-monitoring"
```

Приватный ключ никогда не передается и не коммитится в репозиторий.

### 2. Копирование публичного ключа на сервер

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@203.0.113.10

ssh user@203.0.113.10
```

после этого отключить вход по паролю на сервере


### 3. Передача проекта

```bash
tar -czf - --exclude='.git' --exclude='*.log' . \
  | ssh user@203.0.113.10 "mkdir -p ~/apps/infra-monitoring-project && tar -xzf - -C ~/apps/infra-monitoring-project"
```

### 4. Деплой

```bash
tar -czf - --exclude='.git' --exclude='*.log' . \
  | ssh user@203.0.113.10 "mkdir -p ~/apps/infra-monitoring-project && tar -xzf - -C ~/apps/infra-monitoring-project"

ssh user@203.0.113.10 << 'EOF'
cd ~/apps/infra-monitoring-project
chmod +x check_api.sh analyze_logs.sh
docker compose pull
docker compose up -d
./check_api.sh http://localhost:80
```
