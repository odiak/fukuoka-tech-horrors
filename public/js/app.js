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

app.directive('story', function() {
  return {
    restrict: 'A',
    template: '\
      <div class="title">\
        <a ng-href="/stories/{{story.id}}">{{story.title}}</a>\
      </div>\
      <img class="icon" ng-src="{{story.author.icon}}">\
      <span class="username">\
        {{story.author.name}}&nbsp;\
        <span class="text-muted">@{{story.author.screen_name}}</span>\
      </span>\
      <span class="label label-primary">\
        {{story.votes_count}} こわいね\
      </span>\
    '
  };
});

app.run(['$rootScope', 'currentUser', function($rootScope, currentUser) {
  $rootScope.currentUser = currentUser;
}]);


app.controller('IndexCtrl', ['$http', function($http) {
  var _this = this;
  this.limit = 5;
  this.recentStories;
  this.popularStories;

  $http.get('/api/stories/recent', {params: {limit: this.limit}})
  .success(function(data) {
    _this.recentStories = data.stories;
  });

  $http.get('/api/stories/top', {params: {limit: this.limit}})
  .success(function(data) {
    _this.popularStories = data.stories;
  });
}]);

app.controller('RecentStoriesCtrl', ['$http', function($http) {
  var _this = this, limit = 50;
  this.loadingStories = false;
  this.noMoreStories = false;
  this.stories = []

  this.loadStories = function() {
    this.loadingStories = true
    $http.get('/api/stories/recent', {
      params: {limit: limit, offset: this.stories.length}
    })
    .success(function(data) {
      var stories = data.stories;
      _this.loadingStories = false;
      Array.prototype.push.apply(_this.stories, stories);
      if (stories.length < limit) {
        _this.noMoreStories = true;
      }
    });
  };

  this.loadStories();
}]);

app.controller('PopularStoriesCtrl', ['$http', function($http) {
  var _this = this, limit = 50;
  this.noMoreStories = false;
  this.loadingStories = false;
  this.stories = []

  this.loadStories = function() {
    this.loadingStories = true
    $http.get('/api/stories/top', {
      params: {limit: limit, offset: this.stories.length}
    })
    .success(function(data) {
      var stories = data.stories;
      _this.loadingStories = false;
      Array.prototype.push.apply(_this.stories, stories);
      if (stories.length < limit) {
        _this.noMoreStories = true;
      }
    });
  };

  this.loadStories();
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

  this.unvote = function() {
    var _this = this;
    if (this.story.voted) {
      $http.put('/api/stories/' + this.story.id + '/unvote')
      .success(function(unvoted) {
        _this.story.voted = false;
        if (unvoted) {
          _this.story.votes_count -= 1;
        }
      });
    }
  };

  this.vote = function() {
    var _this = this;
    if (!this.story.voted) {
      $http.put('/api/stories/' + this.story.id + '/vote')
      .success(function(voted) {
        _this.story.voted = true;
        if (voted) {
          _this.story.votes_count += 1;
        }
      });
    }
  };

  this.loadStory();
}]);

})();
