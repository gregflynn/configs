#! /bin/bash

function dock() {
    case $1 in
        up)
            docker-compose up "${@:2}"
        ;;
        build)
            docker-compose up --build "${@:2}"
        ;;
        down)
            docker-compose down "${@:2}"
        ;;
        bash)
            docker-compose exec "$2" bash
        ;;
        purge)
            case $2 in
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
            echo "Usage: dock [up|down|build|bash] [docker-compose alias]"
            echo "       dock purge [containers|images|volumes]"
        ;;
    esac
}
