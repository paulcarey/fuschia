// Note that the function names adhere to the RelaxDB convention of design_doc-view_name-func-type
// CouchDB expects anonymous functions

function fuschia-to_doc-map(doc) {
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

function fuschia-from_doc-map(doc) {
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
