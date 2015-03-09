// For more information see: http://emberjs.com/guides/routing/
App.Router.reopen({
  location: 'auto',
  rootURL: '/'
})

App.Router.map(function() {
  this.resource('fares', { path: '/' });
  this.resource('fares-errors', { path: '/error/' });
	this.resource('fares-results', { path: '/fares/'});
});
