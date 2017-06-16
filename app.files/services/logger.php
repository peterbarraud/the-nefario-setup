<?php
// TODO: Make this a singleton
class Logger {
    public function __construct($filename=null, $lineseparator=null) {
        $this->logfilename = $filename;
        if ($this->logfilename == null){
            $this->logfilename = debug_backtrace()[1]['function'] . '.log';
        }
        $this->linenumber = 0;
        $this->lastlineprinted = '';
        $this->sepchar = $lineseparator;
        if ($lineseparator == null){
            $this->sepchar = 'x';
        }
    }
    public function println($blocktoprint){
        $this->print("$blocktoprint\n");
    }
    public function print($blocktoprint){
        file_put_contents($this->logfilename,"$blocktoprint", FILE_APPEND);
    }
    public function printinc(){
        $this->println($this->linenumber);
        $this->linenumber += 1;
    }
    public function printsep(){
        $this->println(str_repeat("$this->sepchar", strlen($this->lastlineprinted)));
    }
}

?>