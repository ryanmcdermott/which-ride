App.FaresView = Ember.View.extend({
  insertData: function (id) {
    var that = this;
    this.$(id).geocomplete().bind("geocode:result", function (event, result) {
      that.$(id).attr('data-latitude', result.geometry.location.k);
      that.$(id).attr('data-longitude', result.geometry.location.D);
      that.$(id).attr('data-city', result.address_components[3].long_name);
      that.$(id).attr('data-state', result.address_components[5].short_name);
      that.$(id).attr('data-country', result.address_components[6].short_name);
    });
  },

  didInsertElement : function () {
    this.insertData('#origin');
    this.insertData('#destination');
  }
});