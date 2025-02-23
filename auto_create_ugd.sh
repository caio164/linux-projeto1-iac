#!/bin/bash

# Este foi criando em chat gpt para esboçar a ideia que tive durante o desafio
# em breve estare disponibilizando o código de outro script que fiz para resolver o desafio



# Função para exibir barra de progresso
progress_bar() {
    local duration=$1
    local elapsed=0
    echo -ne "["
    while [ $elapsed -lt $duration ]; do
        echo -ne "#"
        sleep 0.1
        ((elapsed++))
    done
    echo -e "]"
}

# Solicitar confirmação do técnico
while true; do
    read -p "Deseja criar os grupos e usuários agora? (s/n): " CONFIRM
    if [[ "$CONFIRM" == "s" || "$CONFIRM" == "n" ]]; then
        break
    else
        echo "Opção inválida. Digite 's' para sim ou 'n' para não."
    fi
done

if [[ "$CONFIRM" != "s" ]]; then
    echo "Operação cancelada pelo técnico."
    exit 1
fi

# Criar grupos e usuários dinamicamente
declare -A USERS
GROUPS=()
DEFAULT_PASSWORD="Senha123"

while true; do
    read -p "Digite o nome do grupo (ou pressione Enter para finalizar): " GROUP_NAME
    if [[ -z "$GROUP_NAME" ]]; then
        break
    fi
    GROUPS+=("$GROUP_NAME")
    sudo groupadd "$GROUP_NAME"
    echo "Grupo $GROUP_NAME criado."
    
    USERS[$GROUP_NAME]=()
    
    while true; do
        read -p "Digite o nome do usuário para o grupo $GROUP_NAME (ou pressione Enter para finalizar): " USER_NAME
        if [[ -z "$USER_NAME" ]]; then
            break
        fi
        USERS[$GROUP_NAME]+=("$USER_NAME")
        sudo useradd -m -G "$GROUP_NAME" "$USER_NAME"
        echo "$USER_NAME:$DEFAULT_PASSWORD" | sudo chpasswd
        sudo passwd --expire "$USER_NAME"
        echo "Usuário $USER_NAME criado com senha padrão e deverá alterá-la no primeiro login."
    done
done

echo "Grupos e usuários cadastrados!"

# Criando diretórios
echo "Criando diretórios..."
progress_bar 10
for GROUP in "${GROUPS[@]}"; do
    sudo mkdir -p "/empresas/$GROUP"
done
echo "Pastas criadas!"

# Criando pastas individuais para cada usuário
echo "Criando pastas individuais..."
progress_bar 15
for GROUP in "${GROUPS[@]}"; do
    for USER in "${USERS[$GROUP][@]}"; do
        sudo mkdir -p "/empresas/$GROUP/$USER"
        sudo chown "$USER:$GROUP" "/empresas/$GROUP/$USER"
        sudo chmod 700 "/empresas/$GROUP/$USER"
    done
done
echo "Pastas individuais criadas e permissões aplicadas!"

# Configurando permissões dos diretórios principais
echo "Configurando permissões..."
progress_bar 10
for GROUP in "${GROUPS[@]}"; do
    sudo chown :"$GROUP" "/empresas/$GROUP"
    sudo chmod 770 "/empresas/$GROUP"
done
echo "Permissões aplicadas!"

echo "Tudo pronto!"
