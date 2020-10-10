// // taken from  by https://github.com/reactjs/redux/blob/master/examples/real-world/middleware/api.js

// type IApiCallMethod = 'GET' | 'POST' | 'PATCH';

// export interface IApiCallData {
//   endpoint: string;
//   method?: IApiCallMethod;
//   // fetching, onSuccess, onFailure
//   types: string[];
//   body?: any;
//   successMessage?: string;
// }

// const CALL_API = 'CALL_API';

// export interface IApiAction {
//   CALL_API: IApiCallData;
// }

// function doApiCall(store, apiCallData: IApiCallData) {

//   const params: any = {
//     headers: {}
//   };
//   params.method = apiCallData.method || 'GET';
//   params.body = JSON.stringify(apiCallData.body);
//   if (params.body) {
//     params.headers['Accept'] = 'application/json';
//     params.headers['Content-Type']  = 'application/json';
//   }


//   return fetch(`http://localhost:8080${apiCallData.endpoint}`, params)
//     .then(response =>
//       response.json().then(json => ({ json, response }))
//     ).then(({ json, response }) => {
//       if (!response.ok) {
//         return Promise.reject(json);
//       }

//       return json;
//     });
// }

// export default store => next => action => {
//   function actionWith(data) {
//     const finalAction = Object.assign({}, action, data);
//     delete finalAction[CALL_API];
//     return finalAction;
//   }

//   const callAPI: IApiCallData = action[CALL_API];
//   if (typeof callAPI === 'undefined') {
//     // not an API call
//     return next(action);
//   }


//   const { endpoint, types } = callAPI;

//   const [requestType, successType, failureType] = types;

//   // before sending the request: send action that request begins
//   next(actionWith({ type: requestType }));

//   return doApiCall(store, callAPI).then(
//     response => next(actionWith({payload: response, type: successType, success: callAPI.successMessage})),
//     error => next(actionWith({
//       type: failureType,
//       error: error.message || 'Something bad happened'
//     }))
//   );
// };
