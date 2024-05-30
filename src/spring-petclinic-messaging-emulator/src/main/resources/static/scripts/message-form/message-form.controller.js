'use strict';

angular.module('messageForm')
    .controller('MessageFormController', ["$http", '$state', '$stateParams', function ($http, $state, $stateParams) {
        var self = this;

        self.submit = function () {
            const msg = {
                petId: self.petId,
                message: self.message
            }

            let req = $http.post('asb', msg);
            req.then(function (response) {
                if (response.status >= 200 && response.status < 300) {
                    self.result = response.data;
                } else {
                    self.result = "Error: " + response.data;
                }
                // if (response.status >= 200 && response.status < 400 && response.data.ok === true) {
                //     self.result = "New message processed. ID: " + response.data.correlationId;
                // } else {
                //     self.result = "Error: " + response.data.description;
                // }
            }).catch(function (response) {
                self.result =response;
            });
        }
    }]);
