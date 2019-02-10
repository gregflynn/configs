#! /bin/bash


__dotsan__dock__manage__dir="$HOME/.dock_manager"
__dotsan__dock__manage__file="$__dotsan__dock__manage__dir/docker-compose.yaml"


function __dock__hl {
    __dsc__ncho "$1" yellow
}


function __dock__opt {
    __dsc__ncho "$1" p p i
}


function __dock__help {
    local cmd=$(__dock__hl COMMAND)
    local svc=$(__dock__opt 'service')
    local svcs=$(__dock__opt '[service[, service2]]')

    echo "    Docker command and system wrapper

    $(echo -en $'\uf061') dock $cmd $(__sys__opt "[service]")

    $(__dock__hl help)
        - show this help message

    Docker Compose Commands
        $(__dock__opt '(using the current working directory)')

        $(__dock__hl bash) $svc
            - execute a bash shell in the given service container

        $(__dock__hl bg) $svcs
            - bring up all or certain services in the background

        $(__dock__hl build) $svcs
            - build and bring up all or certain services in the foreground

        $(__dock__hl down) $svcs
            - bring down all or certain services

        $(__dock__hl edit)
            - edit the current docker compose file

        $(__dock__hl ps)
            - list running containers

        $(__dock__hl restart) $svcs
            - restart all or certain services

        $(__dock__hl up) $svcs
            - bring up all or certain services in the foreground

    Docker System Commands
        $(__dock__opt '(system-wide commands)')

        $(__dock__hl purge) $(__dock__opt 'all|containers|images|volumes')
            - purge docker containers, images, or volumes

        $(__dock__hl sys) $(__dock__opt '... docker compose commands')
            - wrapper for individual docker compose commands at the user level
    "
}


function __dock__completion {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "dock" ]]; then
        opts="help bash bg build down ps restart up purge sys"
    fi

    case "${COMP_WORDS[1]}" in
        purge)
            opts="all containers images volumes"
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F __dock__completion dock


function dock {
    local services="${@:2}"

    case $1 in
        bash)    __dock__bash    "$2"        ;;
        bg)      __dock__bg      "$services" ;;
        build)   __dock__build   "$services" ;;
        down)    __dock__down    "$services" ;;
        edit)    __dock__edit                ;;
        restart) __dock__restart "$services" ;;
        ps)      __dock__ps                  ;;
        up)      __dock__up      "$services" ;;
        purge)   __dock__purge   "$services" ;;
        sys)     __dock__sys     ${@:2}      ;;
        *)       __dock__help                ;;
    esac
}


function __dock__bash {
    # open a bash prompt on the given container name
    # $1 name of the container to start a prompt on
    docker-compose exec $1 bash
}


function __dock__build {
    # build one or more docker services
    # [$1] optional list of services to start
    docker-compose up --build $1
}


function __dock__down {
    # bring down one or more services
    # [$1] optional list of services to bring down
    if [[ "$1" == "" ]]; then
        docker-compose down
    else
        docker-compose stop $1
    fi
}


function __dock__edit {
    # edit the current docker compose
    vim -c ":lcd %:p:h" docker-compose.y*
}


function __dock__ps {
    # list out running containers
    docker-compose ps
}


function __dock__restart {
    # restart one or more services
    # [$1] optional list of services to restart
    docker-compose restart $1
}


function __dock__up {
    # bring up one or more services
    # [$1] optional list of services to bring up
    if [[ "$1" == "" ]]; then
        docker-compose up
    else
        docker-compose up $1
    fi
}


function __dock__bg {
    # bring up one or more services in the background
    # [$1] optional list of services to bring up
    if [[ "$1" == "" ]]; then
        docker-compose up -d
    else
        docker-compose up -d $1
    fi
}


function __dock__purge {
    # purge docker cached files
    # $1 all|containers|images|volumes
    case $1 in
        all)
            dock purge containers
            dock purge images
            dock purge volumes
        ;;
        containers)
            docker stop $(docker ps -a -q) > /dev/null 2>&1
            docker rm $(docker ps -a -f status=exited -q)
        ;;
        images)
            docker rmi $(docker images -a -q)
        ;;
        volumes)
            docker volume rm $(docker volume ls -f dangling=true -q)
        ;;
        *) __dock__help ;;
    esac
}


function __dock__sys {
    __dock__hl "Docker User Service\n"

    if ! [[ -e ${__dotsan__dock__manage__file} ]]; then
        __dock__hl "First time setup...\n"
        mkdir ${__dotsan__dock__manage__dir}

        # write default docker compose file
        echo "version: '3'
#services:
    #[name_of_service]:
        # if using stock image
        #image: 'postgres:9.6
        # if using custom
        #build:
            #dockerfile: Dockerfile.foo
            #context: .
        #ports:
            # host port:container local port
            #- 9000:5432
        #environment:
            # set environment variables
            #POSTGRES_USER: postgress
            #POSTGRES_PASSWORD: password
        " > ${__dotsan__dock__manage__file}
    fi

    pushd ${__dotsan__dock__manage__dir} > /dev/null

    dock ${@:1}

    popd > /dev/null
}
