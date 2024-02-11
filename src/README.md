## Ferramentas

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](http://vagrantup.com)
- [Cmder](https://cmder.app/)

## Comandos

- `vagrant plugin install vagrant-disksize` permite aumento de disco no Vagrantfile
- `vagrant up` lê Vagrantfile e provisiona máquina
- `vagrant ssh` loga na máquina
    - `ps -ef | grep -i mysql` verifica se o MySQL está rodando
    - `mysql -u devops -p` e `mysql -u devops_dev -p` conectar ao servidor de banco de dados (senha _mestre_)
        - `show databases` lista banco de dados

### Instalando o Jenkins
- `cd /vagrant/scripts` acessa pasta de scripts
- `sudo ./jenkins.sh` executa arquivo de instalaçãoo do Jenkins
- `ip address` busca IP da máquina e acessar IP com porta 8080
- `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` obtém valor chave (ativar Jenkins)
- `sudo usermod -aG docker $USER` | `sudo usermod -aG docker jenkins` adicionar usuário especificado ao grupo docker
- `vagrant reload` recarrega Vagrant (ler alterações do Vagrantfile, por exemplo)

### Configuração do git e versionamento do código

- `ssh-keygen -t rsa -b 4096 -C "<seu-usuario>@gmail.com"` cria chave SSH localmente
- `git config --global user.name "<seu-usuario>"` configurar usuário Git
- `git config --global user.email <seu-usuario>@<seu-providor>` configurar e-mail Git
- `cat ~/.ssh/id_rsa.pub` acessar conteúdo da chave pública criada e inserir valor na chave SSH a ser criada no GitHub ou outro repositório remoto
- `ssh -T git@github.com` testa chave

### Inserir aplicação no diretório compartilhado app
- `cd /vagrant/jenkins-todo-list`
- `git init`
- `git add .`
- `git commit -m "mensagem commit"`
- `git log`

### Criar um repositório no github: jenkins-todo-list
- `git remote add origin git@github.com:<seu-usuario>/jenkins-todo-list.git`
- `git push -u origin master`

### Configurar chave privada criada no ambiente da VM no Jenkins

- `Credentials -> Jenkins -> Global Credentials -> Add Crendentials -> SSH Username with private key [ github-ssh ]` caminho para criar chave SSH no Jenkins
- `cat ~/.ssh/id_rsa` acessar conteúdo da chave privada criada e inserir valor na chave SSH a ser criada no Jenkins

### Criar job monitoramento repositório
- `Novo job -> jenkins-todo-list-principal -> Freestyle project` Esse job vai fazer o build do projeto e registrar a imagem no repositório.

### Gerenciamento de código fonte:
- Git
    - Repository URL: `git@github.com:<seu-usuario>/jenkins-todo-list.git` [SSH]
    - Credentials: `git (github-ssh)`
    - Branch: `master`

> Pode ser necessário configurar o `Git Host Key Verification Configuration` em **Security** nas configurações do Jenkins

### Trigger de builds
- Pool SCM: * * * * *

### Ambiente de build
- Delete workspace before build starts

### Configurar aplicação
- `vi .env` cria .env
- `sudo pip3 install virtualenv nose coverage nosexcover pylint` instala venv e dependências do Python

### Criando e ativando o venv (dev)
- `virtualenv --always-copy  venv-django-todolist` cria _virtualenv_ para isolar pacotes da aplicação
- `source venv-django-todolist/bin/activate` ativa _virtualenv_
- `pip install -r requirements.txt` instala dependências do `requirements.txt`

### Fazendo a migração inicial dos dados (específico da aplicação Django)
- `python manage.py makemigrations` cria migrações do banco baseado nos modelos
- `python manage.py migrate` migra o banco

### Criando o superuser para acessar a app (específico da aplicação Django)
- `python manage.py createsuperuser` cria super usuário (root)

> Repetir o processo de migração para o ambiente de produção (alterar apontamentos no .env)

### Verificar o ip do servidor
- `ip addr`

### Rodando a app
- `python manage.py runserver 0:8000` starta app em http://192.168.33.10:8000`

### Expor o daemon (acesso remoto) do Docker
- `sudo mkdir -p /etc/systemd/system/docker.service.d/` cria diretório para configuração
- `sudo vi /etc/systemd/system/docker.service.d/override.conf` cria arquivo de configuração para o seguinte conteúdo:

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
```

- `sudo systemctl daemon-reload` recarrega _daemon_ Docker
- `sudo systemctl restart docker.service` reinicia serviço Docker

### Instalando o plugin Docker no Jenkins
- Gerenciar Jenkins -> Gerenciar Plugins -> Disponíveis
- Pesquisar por `docker`
- Instalar sem reiniciar -> Depois reiniciar o Jenkins
- Gerenciar Jenkins -> Configurar o sistema -> Nuvem
    - Name: docker
    - URI: tcp://127.0.0.1:2376 (local)
    - Enabled

### Editando job
- Build step 1: Executar Shell
```
# Validando a sintaxe do Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile
```

- Build step 2: Build/Publish Docker Image
    - Directory for Dockerfile: ./
    - Cloud: docker
    - Image: robsonteixeira/django-todolist

### Instalando o plugin Config File Provider no Jenkins
- Gerenciar Jenkins -> Gerenciar Plugins -> Disponíveis
- Pesquisar por `config file provider`

### Configurar o Managed Files para Dev
- Gerenciar Jenkins -> Gerenciar arquivos -> Adicione uma nova configuração -> Arquivo customizável
- Name: .env-dev
- Content: 
```
[config]
# Secret configuration
SECRET_KEY = 'r*5ltfzw-61ksdm41fuul8+hxs$86yo9%k1%k=(!@=-wv4qtyv'
# conf
DEBUG=True
# Database
DB_NAME = "todo_dev"
DB_USER = "devops_dev"
DB_PASSWORD = "mestre"
DB_HOST = "localhost"
DB_PORT = "3306"
```

### Configurar o Managed Files para Prod
- Gerenciar Jenkins -> Gerenciar arquivos -> Adicione uma nova configuração -> Arquivo customizável
- Name: .env-prod
- Content: 
```
[config]
# Secret configuration
SECRET_KEY = 'r*5ltfzw-61ksdm41fuul8+hxs$86yo9%k1%k=(!@=-wv4qtyv'
# conf
DEBUG=False
# Database
DB_NAME = "todo"
DB_USER = "devops"
DB_PASSWORD = "mestre"
DB_HOST = "localhost"
DB_PORT = "3306"
```

### Editando job
- Adicionar passo no ambiente de build: Provide Configuration Files
- File: .env-dev
- Target: .env

- Build step 3: Executar Shell

```
#!/bin/sh

# Subindo o container de teste
docker run -d -p 82:8000 -v /var/run/mysqld/mysqld.sock:/var/run/mysqld/mysqld.sock -v /var/lib/jenkins/workspace/jenkins-todo-list-principal/.env:/usr/src/app/src/.env --name=todo-list-teste robsonteixeira/django-todolist

# Testando a imagem
docker exec -i todo-list-teste python manage.py test --keep
exit_code=$?

# Derrubando o container velho
docker rm -f todo-list-teste

if [ $exit_code -ne 0 ]; then
    exit 1
fi
```