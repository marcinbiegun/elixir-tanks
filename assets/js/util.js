export const statusSet = (type, data) => {
  const preparedData = "" + type + ": " + data;
  const elId = "status-" + type;
  const el = document.getElementById(elId);
  if (el != null) {
    el.innerHTML = preparedData;
  } else {
    const ul = document.getElementById("status");
    const li = document.createElement("li");
    li.id = elId;
    const text = document.createTextNode(preparedData);
    li.appendChild(text);
    ul.appendChild(li);
  }
};

export const consoleAppend = (data) => {
  const timestamp = new Date().toISOString().split("T")[1].split(".")[0];
  const preparedData = "[" + timestamp + "]" + " " + data;

  const ul = document.getElementById("console");
  const li = document.createElement("li");
  const text = document.createTextNode(preparedData);
  li.appendChild(text);
  ul.appendChild(li);
};

export const readGameIdFromURL = () => {
  var regex = /\/games\/[a-zA-z0-9]*/gi;
  var result = regex.exec(location.pathname);
  if (result == null) {
    return null;
  }
  return result[0].split("/")[2];
};
