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
