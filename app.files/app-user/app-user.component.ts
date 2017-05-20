import { Component, OnInit } from '@angular/core';

import { RestService } from '../rest.service';

@Component({
  selector: 'app-user',
  templateUrl: './app-user.component.html',
  styleUrls: ['./app-user.component.css']
})
export class AppUserComponent implements OnInit {
  private selectedUser:any;
  private appUsers;

  constructor(public restService: RestService) {}
  ngOnInit() {
    this.getAppUsers();
  }

  getAppUsers(){
      this.restService.getObjectCollection("appuser")
      .subscribe(retval =>{
        this.appUsers = retval.items;
      });    
  }

  saveUserDetails(namefield){
    this.selectedUser.name = namefield.value;
    this.restService.saveObject("appuser",this.selectedUser)
    .subscribe(retval =>{
      console.log(retval);
    });
  }

  deleteUser(appUserid){
    this.restService.deleteObjectById("appuser",appUserid)
    .subscribe(retval =>{
      this.appUsers = retval.items;
    });
  }



}
