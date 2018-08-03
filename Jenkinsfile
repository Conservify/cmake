timestamps {
    node () {
        stage ('git') {
            checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/Conservify/cmake.git']]])
        }
    }
}
