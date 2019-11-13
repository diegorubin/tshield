## About TShield 
### Tipos de mocks
**VCR**
- Define o mapeamento no arquivo tshield.yml (dominio, path, name, ...)
- Ao acessar a primeira vez o TShield utilizará o mapeamento fornecido, fará a request original ao destino real e gravará na pasta `requests`
- Caso a request já existe "gravada" na pasta `requests` o TShield apenas retornará a resposta salva

**Custom controller**
- Permite a exposição de um path e mapear um método que receberá a requisição (params e request)
- Dessa forma é possível interagir com a request e gerar um response customizado
- Para expor a URL basta criar o arquivo dentro da pasta `controller`
- **OBS**: Essa é a única maneira de manipular o response de acordo com o body de requisições (para utilizar com mocks de SOAP, por exemplo.)

**Pattern Matching**
- Permite definir o match dos mocks por `path param (regex)`, `query param` e `headers`
- Para configurar um matching basta criar um arquivo .json com as infos da request (method, path e response)

**Sessions**
- É possível definir o escopo de uma execução utlizando sessões
- Dessa forma é possível criar cenários de variação de sucesso/erro com facilidade
- No `VCR` as resposta são salvas em uma subpasta com o nome da sessão
    - No caso de multiplas request dentro da mesma sessão são criados arquivos numerados iniciando em 0. Ex: (`0.content`, `0.json`, `1.content`, `1.json`)
    - Neste caso, a primeira chamada vai retornar o mock do arquivo `0.content` e seu cabeçalho. A segunda chamada vai retornar o conteúdo do arquivo `1.content`.
- No `Pattern Matching` basta definir o json com os atributos `session` e `stubs`
    - No case de multiplas request dentro da mesma sessão e o objeto `response` do matching for um array as respostas serão retornadas em uma lista circular

**Priority**
- A ordem de prioridade em caso de conflitos de matching é a seguinte
    - Fora de sessão:
        - Custom controller -> Pattern Matching -> VCR
    - Dentro de sessão:
        - Custom controller -> Pattern Matching (com sessão) -> Pattern Matching (sem sessão) -> VCR (com sessão)

