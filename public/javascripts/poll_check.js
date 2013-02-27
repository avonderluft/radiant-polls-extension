// In order to cache pages with  poll functionality we put the logic in the client.
// In other words, rather than having the server check the cookie status 
// to see if the user has taken the poll and then decide to send either the questions or results, 
// we should send both options to the client.  Then, using the following javascript on the browser, 
// check the cookie and display either the poll options or the poll results.

// Read a cookie
function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) { 
      var a=c.substring(nameEQ.length,c.length);
      /* alert(a);*/
return a;
    }
  }
  return null;
}

// Client-side Poll processing - check for presence of poll
// If present, read cookie to see if it has been submitted by this user	
function checkForPoll () {
  var poll = document.getElementById('poll');
  if (poll!=null) {
    var pollDivs = poll.getElementsByTagName("div");
    var pollName = pollDivs[1].id;
    var submittedDiv = document.getElementById(pollName + "_submitted");
    var unsubmittedDiv = document.getElementById(pollName + "_unsubmitted");
    theCookie=readCookie(pollName);
    if (theCookie!=null) {
      unsubmittedDiv.parentNode.removeChild(unsubmittedDiv);
      submittedDiv.style.display = "inline";
    } else {
      submittedDiv.parentNode.removeChild(submittedDiv);
      unsubmittedDiv.style.display = "inline";
    }
  } 
}

// ensure radio button selected
function checkRadioSelection (frmId, rbGroupName) {
  var radios = document.getElementById(frmId).elements[rbGroupName]; 
  for (var i=0; i <radios.length; i++) { 
    if (radios[i].checked) return true;
  }
  alert("Please make a selection first...");
  return false;  
}

