#! /bin/bash

function dock {
    case $1 in
        up)
            docker-compose up "${@:2}"
        ;;
        build)
            docker-compose up --build "${@:2}"
        ;;
        down)
            if [[ "${@:2}" == "" ]]; then
                docker-compose down
            else
                docker-compose stop "${@:2}"
            fi
        ;;
        bash)
            docker-compose exec "$2" bash
        ;;
        restart)
            docker-compose restart "${@:2}"
        ;;
        purge)
            case $2 in
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
                *)
                    echo "Usage: dock purge [containers|images|volumes]"
                ;;
            esac
        ;;
        *)
            echo "Usage: dock [up|down|build|bash|restart] [docker-compose alias]"
            echo "       dock purge [containers|images|volumes]"
        ;;
    esac
}
