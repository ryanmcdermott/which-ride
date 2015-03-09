App.Fare = DS.Model.extend({
	origin: DS.attr(),
	destination: DS.attr(),
	company: DS.attr('string'),
	price: DS.attr('string'),
  image: DS.attr('string')
});