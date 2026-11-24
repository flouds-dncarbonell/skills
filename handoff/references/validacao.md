# Revisar, testar e comitar uma fatia

1. Conferir o diff contra o escopo do handoff e as instruções aplicáveis do projeto. Separar trabalho de outras frentes; não sobrescrever alterações existentes.
2. Rodar os testes pertinentes ao comportamento alterado e os checks exigidos pelo projeto. Em Go: build, vet e testes dos pacotes tocados. Em Svelte: check, build e teste de navegador dos fluxos alterados. Auth e isolamento exigem testes negativos. Schema idempotente deve ser testado no banco novo e no existente.
3. Integração deve usar banco local isolado. Não usar credenciais nem modificar bancos de outro projeto. Para RLS, testar também sob role sem privilégios de superusuário. Nunca copiar a configuração específica do Chatme para outros projetos por suposição.
4. Montar o índice só com a fatia. Arquivo exclusivo: `git add <arquivo>`. Compartilhado: partir do blob do HEAD e aplicar apenas a alteração da fatia; `git update-index --cacheinfo` pode ser usado. Não usar patches `-U0`.
5. Ler o diff staged inteiro e testar o índice em checkout/worktree limpo se houver alterações de outras frentes ou se o AGENTS.md exigir. O commit deve se sustentar sozinho. Falha anterior precisa de evidência no HEAD, registrada no handoff.
6. Comitar com mensagem `feat(<área>): fatia <ID> — <comportamento>`, `fix(...)` ou `docs(...)`, sem `Co-Authored-By`. Conferir status depois e registrar hash, validações, limites e próxima fatia no handoff.

Falha de check novo: corrigir antes de comitar. Se não for possível, registrar `feita SEM commit — <motivo>`; não declarar entregue. Testes locais não comprovam deploy, entrega pelo provedor ou uso no aparelho.
