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
      templateUrl: '/tpls/popular_stories.html',
    })
    .when('/stories/recent', {
      controller: 'RecentStoriesCtrl as recentStories',
      templateUrl: '/tpls/recent_stories.html',
    })
    .when('/stories/:storyId', {
      controller: 'SingleStoryCtrl as singleStory',
      templateUrl: '/tpls/stories/single.html',
    })
    .otherwise('/');
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