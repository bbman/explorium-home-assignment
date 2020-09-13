node ('worker_node1') {
    triggers << cron('0 20 * * MON')
    properties (
        [
            pipelineTriggers(triggers)
        ]
    )
    // get code from our Git repository
    git 'https://github.com/bbman/home-assignment'
    // run script
    sh "./check-sg.sh"
}