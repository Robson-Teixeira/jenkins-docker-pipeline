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