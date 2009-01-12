// _design/fuschia.views.to_doc.map
function (doc) {
  var isDocId = function (str) {
    var res = /[0-9a-f-]+/(str);
    return res && str.length >= 32 && str === res[0];
  };
  
  for(var n in doc) {
    var att = doc[n];
    if (n !== "_id" && isDocId(att)) {
      emit(att, null);
    }
  }
}

// _design/fuschia.views.from_doc.map
function (doc) {
  var isDocId = function (str) {
    var res = /[0-9a-f-]+/(str);
    return res && str.length >= 32 && str === res[0];
  };
  
  for(var n in doc) {
    var att = doc[n];
    if (n !== "_id" && isDocId(att)) {
      emit(doc._id, att);
    }
  }
}
