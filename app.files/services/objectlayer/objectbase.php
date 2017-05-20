<?php
require_once ('datalayer.php');
class objectbase {
    public function __construct($id=null) {
        $this->id = $id;
        $dataLayer = DataLayer::Instance();
        $dataLayer->GetObjectData($this);
    }
    public function Save(){
        $dataLayer = DataLayer::Instance();
        $dataLayer->Save($this);
    }
    public function Delete()
    {
        $dataLayer = DataLayer::Instance();
        $affected_rows = $dataLayer->Delete($this);
        return $affected_rows;
    }
    public function __toString() {
        ob_start();
        var_dump($this);
        return ob_get_clean(); 
        // TODO: Check if this functionality works on the public server. If, then remove the following commented out portion
        // file_put_contents('var-dump.log', $result);
        // foreach ($this as $key => $value) {
        //     if (is_object($value)){
        //         file_put_contents('tostring.log', "$key is object\n");
        //     }
        //     if (is_array($value)){
        //         file_put_contents('tostring.log', "$key\n", FILE_APPEND);
        //         foreach ($value as $key => $arrayvalue) {
        //             file_put_contents('tostring.log', "$key => $arrayvalue\n", FILE_APPEND);
        //         }
        //     }
        //     else {
        //         file_put_contents('tostring.log', "$key => $value\n", FILE_APPEND);
        //         $retval .= "$key => $value\n";
        //     }
        // }        
        // file_put_contents('tostring.log', "====================\n", FILE_APPEND);
        // return $retval;
    }
}

?>