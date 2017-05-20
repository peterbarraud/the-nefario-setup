<?php
require_once ('datalayer.php');
class objectcollectionbase {
    public function __construct($filter=null, $sortby=null, $sortdirection=null) {
        $this->items = array();
        $dataLayer = DataLayer::Instance();
        $classname = str_replace('collection', '', get_class($this));
        $objectIds = $dataLayer->GetObjectIds($classname, $filter, $sortby, $sortdirection);
        require_once($classname . '.php');
		$type = $classname;
        foreach ($objectIds as $id){
            array_push($this->items, new $type($id));
        }
        $this->length = sizeof($this->items);
    }
    public function getnamescollection(){
        $retval = array();
        foreach ($this->items as $item){
            array_push($retval,$item->name);
        }
        return $retval;
    }
    public function __toString() {
        ob_start();
        var_dump($this);
        return ob_get_clean(); 
    }
    
}

?>