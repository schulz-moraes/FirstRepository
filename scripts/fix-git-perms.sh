#!/usr/bin/env bash
set -euo pipefail

# Corrige propriedade e permissões da pasta .git para o usuário atual.
# Uso: ./scripts/fix-git-perms.sh

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ]; then
  repo_root="$(pwd)"
fi
git_dir="$repo_root/.git"

if [ ! -d "$git_dir" ]; then
  echo ".git não encontrado em $repo_root" >&2
  exit 1
fi

# Preferir o usuário que iniciou a sessão; cair para whoami se necessário
user=$(logname 2>/dev/null || whoami)
group=$(id -gn "$user" 2>/dev/null || id -gn)

echo "Ajustando propriedade de '$git_dir' para $user:$group"
if chown -R "$user:$group" "$git_dir" 2>/dev/null; then
  echo "Propriedade ajustada com sucesso"
else
  echo "Falha ao ajustar propriedade. Tente executar com 'sudo' se necessário" >&2
fi

echo "Garantindo hooks executáveis (se existirem)"
for h in pre-push post-commit pre-commit prepare-commit-msg commit-msg pre-rebase; do
  hook_path="$git_dir/hooks/$h"
  if [ -f "$hook_path" ]; then
    chmod +x "$hook_path" || true
    echo "chmod +x $hook_path"
  fi
done

echo "Operação concluída. Verifique com: ls -la $git_dir/hooks"

exit 0
