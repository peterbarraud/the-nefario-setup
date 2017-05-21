import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions } from '@angular/http';
import {Observable} from 'rxjs/Rx';
import 'rxjs/add/operator/map';

@Injectable()
export class RestService {
  hostServerUrl: string = "localhostrestserverlocation"
//   hostServerUrl = "services/rest.api.php/"

  constructor(private http: Http) { }

  newObect(className: string): Observable<any>{
      return this.http.get(this.hostServerUrl + 'getnewobjectbyclassname/' + className + "/")
      .map( (res: Response) =>  res.json() )    
  }

  getObectById(className: string, id: number): Observable<any>{
      return this.http.get(this.hostServerUrl + 'getobjectbyid/' + className + '/' + id + "/")
        .map( (res: Response) =>  res.json() )
  }

  saveObject(className: string, objectToSave:any): Observable<any>{
      let headers = new Headers({ 'Content-Type': 'application/x-www-form-urlencoded' });
      let options = new RequestOptions({ headers: headers });
      let url = this.hostServerUrl + 'saveobject/' + className + "/";
      return this.http.post(url, objectToSave, options)
        .map( (res: Response) =>  res.json() )
  }

  deleteObjectById(className :string, id: number): Observable<any>{
      return this.http.get(this.hostServerUrl + 'deleteobjectbyid/' + className + '/' + id + "/")
        .map( (res: Response) =>  res.json() )
  }

  getObjectCollection(className:string): Observable<any>{
      return this.http.get(this.hostServerUrl + 'getobjectsbyclassname/' + className + '/')
      .map( (res: Response) =>  res.json() )
  }


}
