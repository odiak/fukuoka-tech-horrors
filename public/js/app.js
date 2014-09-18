(function() {

var app = angular.module('Horror', [
  'ui.bootstrap',
  'ngRoute',
]);

app.config(['$routeProvider', '$locationProvider',
    function($routeProvider, $locationProvider) {
  $locationProvider.html5Mode(true);

  $routeProvider
    .when('/', {
      controller: 'IndexCtrl as index',
      templateUrl: '/tpls/index.html',
    })
    .when('/stories/new', {
      controller: 'NewStoryCtrl as newStory',
      templateUrl: '/tpls/stories/new.html',
    })
    .when('/stories/popular', {
      controller: 'PopularStoriesCtrl as popularStories',
      templateUrl: '/tpls/stories/popular.html',
    })
    .when('/stories/recent', {
      controller: 'RecentStoriesCtrl as recentStories',
      templateUrl: '/tpls/stories/recent.html',
    })
    .when('/stories/:storyId', {
      controller: 'SingleStoryCtrl as singleStory',
      templateUrl: '/tpls/stories/single.html',
    })
    .when('/stories/:storyId/edit', {
      controller: 'EditStoryCtrl as editStory',
      templateUrl: '/tpls/stories/edit.html',
    })
    .otherwise('/');
}]);

app.factory('currentUser', ['$http', function($http) {
  var currentUser = {};
  $http.get('/api/current_user')
  .success(function(user) {
    var prop;
    for (prop in user) {
      currentUser[prop] = user[prop];
    }
    currentUser._loaded = true
  })
  .error(function() {
    currentUser._loaded = true;
  });
  return currentUser;
}]);

app.run(['$rootScope', 'currentUser', function($rootScope, currentUser) {
  $rootScope.currentUser = currentUser;
}]);

app.controller('IndexCtrl', ['$http', function($http) {
}]);

app.controller('NewStoryCtrl', ['$http', '$location',
    function($http, $location) {

  this.save = function() {
    $http.post('/api/stories', {
      title: this.title,
      body: this.body,
    }).success(function(story) {
      $location.path('/stories/' + story.id);
    }).error(function() {
      alert('error');
    });
  };
}]);

app.controller('SingleStoryCtrl', ['$http', '$routeParams',
    function($http, $routeParams) {

  this.storyId = $routeParams.storyId && +$routeParams.storyId;

  this.loadStory = function() {
    var _this = this;
    $http.get('/api/stories/' + this.storyId)
    .success(function(story) {
      _this.story = story;
    });
  };

  this.loadStory();
}]);

})();
