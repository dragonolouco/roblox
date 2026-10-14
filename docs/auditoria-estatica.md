# Louco Hub — auditoria estática do script Lua

**Data:** 14 de outubro de 2026  
**Arquivo analisado:** `pasted_content.txt`, fornecido como anexo (6.468 linhas; 183.428 bytes)  
**Repositório:** `dragonolouco/roblox`

## Resumo

O anexo é um script de automação para Roblox/Blox Fruits que carrega módulos remotos, cria uma interface, automatiza ações de jogo e interage diretamente com remotes do cliente. Também inclui verificações anti-detecção e funções típicas de ambiente de executor. Isso não é um pacote comum de código de jogo no Roblox Studio.

O conteúdo foi analisado estaticamente. **Nada foi executado.** Os três arquivos de texto hospedados no GitHub referenciados pelo script foram lidos como texto, sem execução. A biblioteca principal declara ter sido protegida pelo **Luraph Obfuscator v15.1**; não foi desofuscada nem tratada como confiável. Ofuscação não é evidência de criptografia, nem prova por si só de intenção maliciosa.

Não há, no material inspecionado, uma região criptografada isolada que possa ser substituída com segurança por uma implementação equivalente. A biblioteca ofuscada é código externo de terceiros; adivinhar sua função interna ou recriá-la sem especificação seria especulativo. Por isso, este repositório registra os achados, mas não modifica nem reconstrói o exploit.

## URLs e comportamento observado

| URL/recurso | Uso observado no script | Resultado da inspeção |
|---|---|---|
| `https://raw.githubusercontent.com/AhmadV99/Main/refs/heads/main/Library/Lib_5.5.0.lua` | Baixado e compilado dinamicamente nas linhas 155–158; seu resultado é usado para criar a janela e a interface. | O texto remoto começa com um aviso do Luraph Obfuscator v15.1 e contém código fortemente ofuscado. Sem desofuscação/execução, não foi possível validar o comportamento interno. SHA-256 do texto consultado: `b682e7801676922cf86e79013c91633a42de90ef65c5a2569ddd666fa508b3a7`. |
| `https://raw.githubusercontent.com/AhmadV99/Main/main/Library/Example/FuncsV3` | Baixado e compilado dinamicamente nas linhas 161–165. | Código legível de helpers para Toggle, Button, Dropdown e Textbox, incluindo valores padrão e leitura de configuração salva. SHA-256: `a99dfcc90ed3cf6496d6d909ff3c558f3a7d7744aaf9c9e5fbf08f73a714af5a`. |
| `https://raw.githubusercontent.com/AhmadV99/Main/main/Codes_BloxFruit` | Baixado e passado a `loadstring` quando o usuário aciona “Redeem All Codes” (linhas 6361–6364). | Código legível que retorna uma lista Lua de códigos de resgate; cada código é enviado ao remote `Redeem`. SHA-256: `e6155c29200479634ffb78be5fd9806e0c05e0032c55f5e9f9a264900668a021`. |
| `https://prvf.onrender.com/data` | Requisição HTTP GET na função `bossData` (linhas 1370–1397). | A resposta é decodificada como JSON e consultada para selecionar entradas de chefes. O script não mostra validação de assinatura ou integridade do JSON antes de usá-lo. O endpoint não foi consultado nesta auditoria. |
| `http://www.roblox.com/asset/?id=9709143733`, `9709149052`, `9709149431`, `9709149680`, `9709150401` | Chaves em uma tabela de classificação de fases lunares, nas linhas 3408–3412. | Endereços de assets do Roblox usados como identificadores; não são carregadores Lua explícitos no trecho. |
| `http://www.roblox.com/asset/?id=9884584522` | Chave em outra tabela, perto da linha 1284. | Identificador de asset do Roblox; não é um carregador Lua explícito no trecho. |

Os arquivos remotos do GitHub são referências mutáveis: o ramo `main` pode mudar depois da auditoria. Os hashes acima identificam apenas as cópias de texto consultadas nesta data; não garantem segurança nem autenticidade do autor.

## Achados de risco relevantes

1. **Execução dinâmica de código remoto:** o script usa `game:HttpGet` seguido de `loadstring` para baixar/compilar fontes externas. Isso permite que o comportamento mude sem alteração no arquivo local.
2. **Biblioteca ofuscada:** o módulo principal não é auditável por leitura simples e seu conteúdo pode mudar na origem. Não é possível afirmar que seja seguro apenas pelo nome, versão ou pelo fato de estar num repositório público.
3. **Anti-análise/anti-detecção:** há verificações com `debug.info`, `LPH_CRASH()` e testes de contexto Studio/servidor que encerram o script quando as condições esperadas falham.
4. **Interação com remotes e automação:** há chamadas a `InvokeServer`/`FireServer`, simulação de entrada, teleporte e automação de atividades. Isso pode violar regras do jogo e provocar sanções à conta.
5. **APIs de executor e hooks:** aparecem funções como `syn.request`, `http_request`, `hookfunction`, `getupvalues`, `firetouchinterest`, `fireclickdetector`, `fireproximityprompt`, além de leitura/escrita de arquivos. Elas não fazem parte do ambiente normal de scripts autorizados do Roblox Studio.
6. **Dados externos não autenticados:** a resposta JSON do endpoint de terceiros é consumida sem validação de integridade visível no trecho examinado.

## Organização feita no repositório

O README foi atualizado para descrever o escopo, e esta auditoria foi adicionada em `docs/auditoria-estatica.md`. O anexo e os módulos remotos **não** foram copiados para o repositório. Também não foram alterados nem recriados os comportamentos de exploit ou de evasão.

## Recomendações

Para um projeto legítimo no Roblox Studio, substitua dependências remotas por módulos próprios, versionados e revisados; não use `loadstring` para código hospedado por terceiros; valide a origem e integridade de qualquer dado externo; remova APIs de executor e verificações anti-detecção; e implemente mecânicas apenas por APIs suportadas e autorizadas. Se a intenção for aprender Lua, a lógica de interface pode ser reimplementada em um projeto de demonstração sem interação com jogos de terceiros ou automação de combate/farming.
