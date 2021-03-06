// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// = require jquery
// = require jquery_ujs
// = require handlebars
// = require devise-otp
// = require_tree .

var textWell = (function () {
  return {
    init: function () {
      $(document).on('click', '.textwell .textwell__expander', function () {
        $(this).parent('.textwell').addClass('textwell--expanded')
      })
    }
  }
})();

var radioSelector = (function () {
  var rs = {
    init: function () {
      $('.radio-button').each(function (index, button) {
        if ($(this).find('input').is(':checked')) {
          $(this).addClass('is-selected')
        }

        $(this).find('input').click(function (e) {
          $(this).parent().siblings().removeClass('is-selected')
          $(this).parent().addClass('is-selected')
        })
      })
    }
  };
  return {
    init: rs.init
  }
})();

var checkboxSelector = (function () {
  var cs = {
    init: function () {
      $('.checkbox').each(function (index, button) {
        if ($(this).find('input').is(':checked')) {
          $(this).addClass('is-selected')
        }

        $(this).find('input').click(function (e) {
          if ($(this).is(':checked')) {
            $(this).parent().addClass('is-selected')
          }else {
            $(this).parent().removeClass('is-selected')
          }
        })
      })
    }
  };
  return {
    init: cs.init
  }
})();

var yesNoButtons = (function () {
  var yn = {
    init: function () {
      $('[data-no]').on('click', function () {
        $('input.boolean-answer').val('0')
      })

      $('[data-yes]').on('click', function () {
        $('input.boolean-answer').val('1')
      })
    }
  };
  return {
    init: yn.init
  }
})();

var yesNoEnumButtons = (function () {
  var yne = {
    init: function () {
      $('[data-enum-no]').on('click', function () {
        $('input.boolean-answer').val('no')
      })

      $('[data-enum-yes]').on('click', function () {
        $('input.boolean-answer').val('yes')
      })
    }
  };
  return {
    init: yne.init
  }
})();

var autoAdvanceTelInputs = (function() {
  var autoAdvance = {
    init: function () {
      $(".form-group > input[type='tel']").keyup(function () {
        if (this.value.length == this.maxLength) {
          var nextInputGroup = $(this).parent(".form-group").next();
          nextInputGroup.find("input").focus();
        }
      })
    }
  };
  return {
    init: autoAdvance.init
  }
})();

var followUpQuestion = (function() {
  var followUp = {
    init: function() {
      // any pre-selected?
      $('.question-with-follow-up__question select').each(function(index, select) {
        $($($(this).find('option:selected')).attr('data-follow-up')).show();
      });
      // handle selection events
      $('.question-with-follow-up__question select').change(function(e) {
        $('.question-with-follow-up__follow-up').hide();
        $('.question-with-follow-up__follow-up input').each(function(index, radio) {
          $(this).prop('checked', false);
        });
        $($($(this).find('option:selected')).attr('data-follow-up')).show();
      });
    }
  };
  return {
    init: followUp.init
  }
})();

var incrementer = (function() {
  var i = {
    increment: function(input) {
      var max = parseInt($(input).attr('max'));
      var value = parseInt($(input).val());
      if(max != undefined) {
        if(value < max) {
          $(input).val(value+1);
        }
      }
      else {
        $(input).val(parseInt($(input).val())+1);
      }
    },
    decrement: function(input) {
      var min = parseInt($(input).attr('min'));
      var value = parseInt($(input).val());
      if(min != undefined) {
        if(value > min) {
          $(input).val(value-1);
        }
      }
      else {
        $(input).val(value-1);
      }

    },
    init: function() {
      $('.incrementer').each(function(index, incrementer) {
        var addButton = $(incrementer).find('.incrementer__add');
        var subtractButton = $(incrementer).find('.incrementer__subtract');
        var input = $(incrementer).find('.text-input');

        $(addButton).click(function(e) {
          i.increment(input);
        });

        $(subtractButton).click(function(e) {
          i.decrement(input);
        });
      });
    }
  }
  return {
    init: i.init
  }
})();

$(document).ready(function () {
  radioSelector.init();
  checkboxSelector.init();
  textWell.init();
  yesNoButtons.init();
  yesNoEnumButtons.init();
  autoAdvanceTelInputs.init();
  followUpQuestion.init();
  incrementer.init();
})
