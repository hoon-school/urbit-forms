import Urbit from '@urbit/http-api';
import { writable } from 'svelte/store';

// init
const urbit = new Urbit("");

// stores
export const metas = writable(null);
export const active = writable("req");
export const responses = writable(null);

// variables
export const frontType = [
      ["text", "statement"], 
      ["text", "short"], 
      ["text", "long"], 
      ["text", "one"],
      ["list", "many"],
//      ["grid",  "grid-one"], 
//      ["grid",  "grid-many"],
      ["text", "linear-discrete"],
      ["text", "linear-continuous"],
//      ["text", "calendar"]
  ]

// store modifiers

export function updateMetas(ship, path) {
  scryUrbit(ship, path).then( res => metas.set(res))
}

export function setActive(ship, id) {
  const s = "/active/" + id
  const r = "/responses/" + id
  scryUrbit(ship, s).then( res => active.set(res))
  scryUrbit(ship, r).then( res => responses.set(res)) 
} 

// metadata pokes
export function editMetadata(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {"medit": data},
    onSuccess: ()=>(updateMetas(urbit.ship, "/metas")),
    onError: ()=>(console.log("error handling"))
})}

// survey pokes

export function deleteSurvey(data) {
  urbit.poke({
      app: "forms",
      mark: "forms-action",
      json: {"delete": data},
      onSuccess: ()=>(afterSurveyDelete()),
      onError: ()=>(console.log("error handling"))
  })
}

function afterSurveyDelete() {
  active.set("req")
  updateMetas(window.ship, "/metas")
}

// question pokes

export function editQuestion(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {"qedit": data},
    onSuccess: ()=>(setActive(urbit.ship, data.surveyid)),
    onError: ()=>(console.log("error handling"))
})}

export function newQuestion(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {"qnew": data},
    onSuccess: ()=>(setActive(urbit.ship, data.surveyid)),
    onError: ()=>(console.log("error handling"))
  })
}

export function delQuestion(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {qdel: data},
    onSuccess: ()=>(setActive(urbit.ship, data.surveyid)),
    onError: ()=>(console.log("error handling"))
  })
}

// answer pokes

export function editDraft(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {dedit: data},
    onSuccess: ()=>(setActive(urbit.ship, data.surveyid)),
    onError: ()=>(console.log("error handling"))
  })
}

export function submitResponse(data) {
  urbit.poke({
    app: "forms",
    mark: "forms-action",
    json: {submit: data},
    onSuccess: ()=>(setActive(urbit.ship, data.surveyid)),
    onError: ()=>(console.log("error handling"))
  })
}

// top panel related

export function requestSurvey(ship, data) {
  let arr = data.split("/")
  urbit.poke({
      app: "forms",
      mark: "forms-action",
      json: {"ask":{"author": arr[0],"slug":arr[1]}},
      onSuccess: ()=>(updateMetas(ship, "/metas")),
      onError: ()=>(console.log("error handling"))
  })
}

export function createSurvey(ship, data) {
  if (data.title && data.description && data.slug) {
    urbit.poke({
      app: "forms",
      mark: "forms-action",
      json: {"create": data},
      onSuccess: ()=>(updateMetas(ship, "/metas")),
      onError: ()=>(console.log("error handling"))
    })
  } else {console.log("details cannot be empty!")}
}

// internal only
function scryUrbit(ship, path) {
  urbit.ship = ship
  const msg = urbit.scry({
    app: "forms",
    path: path,
  })
  return msg
}
