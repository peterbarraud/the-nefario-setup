<?php
  //VERY IMPORTANT
  //these services will NEVER error out.
  //at the service we will stop any errors and send back a good json but packaged with error information
	require 'Slim/Slim.php';
	$app = new Slim();
	//a single rest API is self-sufficient - so how about the db connection is made at the API level
	//this connection object - held inside a global variable or something of that sort is then available to every method, object that is invokved from the API
	//this ensures that a single connection is opened for the entire duration of the API but no more
	//we can then also (brilliant, this one) make full use of db transactions - we can do a full commit / rollback of everything that happened for the duration of the API


	// TODO
	// create the datalayer as a singleton
	// in the rest api, we instantiate the singleton and close the connection in the rest api itselft
	// BIG TODO

	$app->get('/validateuser/:username/:password/', 'getappuser');
	function getappuser($username, $password) {
		require_once('objectlayer/appusercollection.php');
		$filter = array();
		$filter['username'] = $username;
		$filter['password'] = $password;
		$appusers = new appusercollection($filter);
		$retval = array();
		// since the appuser table has a unique constraint on the username field, we'll get one or no app user
		if ($appusers->length == 1){
			$retval['user'] = $appusers->items[0];
			$retval['invaliduser'] = 0;
		}
		else {
			$retval['invaliduser'] = 1;
		}
		allow_cross_domain_calls();
		echo json_encode($retval);
	}
	
	$app->get('/getobjectbyid/:classname/:id/', 'getobjectbyid');
	function getobjectbyid($classname,$id) {
		require_once('objectlayer/' . $classname . '.php');
		$type = $classname;
		$object = new $type($id);
		allow_cross_domain_calls();
		echo json_encode($object);
	}

	$app->get('/getnewobjectbyclassname/:classname/', 'getnewobjectbyclassname');
	function getnewobjectbyclassname($classname) {
		require_once('objectlayer/' . $classname . '.php');
		$type = $classname;
		$object = new $type();
		$type = $classname;
		$object = new $type();
		$type = $classname;
		$object = new $type();
		allow_cross_domain_calls();
		echo json_encode($object);
	}

	$app->get('/getobjectsbyclassname/:classname/', 'getobjectsbyclassname');
	function getobjectsbyclassname($classname) {
		require_once('objectlayer/' . $classname . 'collection.php');
		$type = $classname . 'collection';
		$objectcollection = new $type();
		allow_cross_domain_calls();
		echo json_encode($objectcollection);
	}

	$app->get('/getsortedobjectsbyclassname/:classname/:sortby/:sortdirection/', 'getsortedobjectsbyclassname');
	function getsortedobjectsbyclassname($classname, $soryby, $sortdirection) {
		require_once('objectlayer/' . $classname . 'collection.php');
		$type = $classname . 'collection';
		$objectcollection = new $type(null, $soryby, $sortdirection);
		allow_cross_domain_calls();
		echo json_encode($objectcollection);
	}

	$app->post('/saveobject/:classname/', 'saveobject');
	function saveobject($classname){
		$app = new Slim();
		require_once('objectlayer/' . $classname . '.php');
		$jsonobject = json_decode($app->request()->getBody());
		$object = GetObjectForJSON($jsonobject,$classname);
		$object->Save();
		$retval = array();
		$retval['saveobject'] = $object;
		require_once('objectlayer/' . $classname . 'collection.php');
		$type = $classname . 'collection';
		$objectcollection = new $type();
		$retval['objectcollection'] = $objectcollection;
		allow_cross_domain_calls();
		echo json_encode($retval);
	}
	
	$app->get('/deleteobjectbyid/:classname/:id/', 'deleteobject');
	function deleteobject($classname,$id) {
		require_once('objectlayer/' . $classname . '.php');
		$type = $classname;
		$object = new $type($id);
		$affected_rows = $object->Delete();
		require_once('objectlayer/' . $classname . 'collection.php');
		$type = $classname . 'collection';
		$objectcollection = new $type();
		allow_cross_domain_calls();
		echo json_encode($objectcollection);
	}


	$app->run();

// probably move these to a common.php
function GetObjectForJSON($jsonobject,$className) {
	//TODO: where is the credit for the following code line
	return unserialize(sprintf('O:%d:"%s"%s',strlen($className),$className,strstr(strstr(serialize($jsonobject), '"'), ':')));
}

function allow_cross_domain_calls() {

    // Allow from any origin
    if (isset($_SERVER['HTTP_ORIGIN'])) {
        header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
        header('Access-Control-Allow-Credentials: true');
        header('Access-Control-Max-Age: 86400');    // cache for 1 day
    }

    // Access-Control headers are received during OPTIONS requests
    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
            header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
            header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

        exit(0);
    }

    //echo "You have CORS!";
}
?>
