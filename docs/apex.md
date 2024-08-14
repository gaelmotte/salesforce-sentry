# Usage in Apex

In any class or trigger, you may use the following syntax

// TODO update after packaging

```Apex
try{
    ...
}catch(Exception e){
    Sentry.captureException(e);
    throw e;
}
```
