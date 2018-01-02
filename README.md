# Powershell Script to get installed .NET Templates

`dotnet new --list` will show the currently installed .NET templates on the machine. This powershell script will make an indexed list of these so that those names can be accessed programatially.

```
Index     : 1
Name      : Console Application
ShortName : console
Language  : {[C#],  F#,  VB}
Tags      : {Common, Console}

Index     : 2
Name      : Class library
ShortName : classlib
Language  : {[C#],  F#,  VB}
Tags      : {Common, Library}

Index     : 3
Name      : Unit Test Project
ShortName : mstest
Language  : {[C#],  F#,  VB}
Tags      : {Test, MSTest}

Index     : 4
Name      : xUnit Test Project
ShortName : xunit
Language  : {[C#],  F#,  VB}
Tags      : {Test, xUnit}

Index     : 5
Name      : ASP.NET Core Empty
ShortName : web
Language  : {[C#],  F#}
Tags      : {Web, Empty}

Index     : 6
Name      : ASP.NET Core Web App (Model-View-Controller)
ShortName : mvc
Language  : {[C#],  F#}
Tags      : {Web, MVC}

Index     : 7
Name      : ASP.NET Core Web App
ShortName : razor
Language  : {[C#]}
Tags      : {Web, MVC, Razor Pages}

Index     : 8
Name      : ASP.NET Core with Angular
ShortName : angular
Language  : {[C#]}
Tags      : {Web, MVC, SPA}

Index     : 9
Name      : ASP.NET Core with React.js
ShortName : react
Language  : {[C#]}
Tags      : {Web, MVC, SPA}

Index     : 10
Name      : ASP.NET Core with React.js and Redux
ShortName : reactredux
Language  : {[C#]}
Tags      : {Web, MVC, SPA}

Index     : 11
Name      : ASP.NET Core Web API
ShortName : webapi
Language  : {[C#],  F#}
Tags      : {Web, WebAPI}

Index     : 12
Name      : global.json file
ShortName : globaljson
Language  : {}
Tags      : {Config}

Index     : 13
Name      : NuGet Config
ShortName : nugetconfig
Language  : {}
Tags      : {Config}

Index     : 14
Name      : Web Config
ShortName : webconfig
Language  : {}
Tags      : {Config}

Index     : 15
Name      : Solution File
ShortName : sln
Language  : {}
Tags      : {Solution}

Index     : 16
Name      : Razor Page
ShortName : page
Language  : {}
Tags      : {Web, ASP.NET}

Index     : 17
Name      : MVC ViewImports
ShortName : viewimports
Language  : {}
Tags      : {Web, ASP.NET}

Index     : 18
Name      : MVC ViewStart
ShortName : viewstart
Language  : {}
Tags      : {Web, ASP.NET}
```