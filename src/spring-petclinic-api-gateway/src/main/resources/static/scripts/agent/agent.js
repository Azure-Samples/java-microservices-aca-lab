'use strict';

angular.module('agent', ['ui.router'])
    .config(['$stateProvider', function ($stateProvider) {
        $stateProvider
            .state('agent', {
                parent: 'app',
                url: '/agent',
                template: '<agent></agent>'
            })
    }]);
