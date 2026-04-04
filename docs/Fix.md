Port in Use?**
If you encounter port conflicts with MongoDB:

```bash
# Check who is using the port
sudo netstat -tulnp | grep 27017

# Kill the process (replace <PID> with the process ID)
sudo kill <PID>
```
