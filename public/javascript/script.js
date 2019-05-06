$( document ).ready(function() {
    let $spinner = $('span#image_loading');
    let $timelapseControlButton = $('button#toggle_timelapse');
    let $rebootButton = $('button#reboot');
    let $refreshPreviewButton = $('button#refresh_preview');

    $rebootButton.on('click', function() {
        $.post('/raspi/reboot')
    });

    $('span#logout').on('click', function() {
        $('form#logout_form').submit()
    });

    $('span#toggle_show_password').on('click', function() {
        let $password = $('input#password');
        let $eye = $('i#eye');
        if ($password.prop('type') === 'password') {
            $password.prop('type', 'text');
            $eye.switchClass('fa-eye', 'fa-eye-slash')
        } else {
            $password.prop('type', 'password');
            $eye.switchClass('fa-eye-slash', 'fa-eye')
        }
    });

    function refreshTimelapseControlButton() {
        let $toggleTimelapseText = $('span#toggle_timelapse_text');
        $.get('/raspi/timelapse_running', function(timelapseRunning) {
            if (timelapseRunning === 'true') {
                $toggleTimelapseText.text('Stop timelapse');
            } else {
                $toggleTimelapseText.text('Start timelapse');
            }
        })
    }

    $timelapseControlButton.on('click', function() {
        let $toggleTimelapseLoading = $('span#toggle_timelapse_loading');
        $toggleTimelapseLoading.removeClass('d-none');
        $.post('/raspi/toggle_timelapse', function() {
            refreshTimelapseControlButton();
            $toggleTimelapseLoading.addClass('d-none');
        })
    });

    $refreshPreviewButton.on('click', function() {
        if (!$refreshPreviewButton.hasClass('busy')) {
            $refreshPreviewButton.addClass('busy');
            $spinner.removeClass('d-none');
            $.post('/raspi/update_preview', function() {
                let date = new Date();
                $.when( $("#preview_still").attr("src", 'https://s3.eu-west-2.amazonaws.com/hogcam-photos/preview.jpg' + date.getTime()) ).done(function() {
                    $spinner.addClass('d-none');
                    $refreshPreviewButton.removeClass('busy');
                });
            })
        }
    });

    function refreshTempWarning(temp) {

        let $alertBadge = $('span#alert-badge');

        $alertBadge
            .addClass('d-none')
            .removeClass('badge-danger badge-warning');

        if (temp > 69 && temp <= 79) {
            $alertBadge.removeClass('d-none');
            $alertBadge.addClass('badge-warning');
        } else if (temp > 79) {
            $alertBadge.removeClass('d-none');
            $alertBadge.addClass('badge-danger');
        }
    }

    function refreshRaspberryPiStatus() {
        $.get('/raspi/status', function(response) {
            let status = JSON.parse(response);
            let temp = status['coreTemperature'].split('°')[0];
            $('span#coreTemperature').text(status['coreTemperature']);
            $('span#availbleStorage').text(status['availableStorage']);
            $('span#cameraStatus').text(status['cameraStatus']);
            $('span#uptime').text(status['uptime']);
            refreshTempWarning(temp);
        })
    }

    refreshTimelapseControlButton();
    refreshRaspberryPiStatus();
    window.setInterval(refreshRaspberryPiStatus, 10000);
});
