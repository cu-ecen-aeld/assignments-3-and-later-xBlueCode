#include <syslog.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>


int main(int ac, char **av) {

    openlog("aeld_a2", LOG_PID, LOG_USER);
    if (ac != 3)
    {
        syslog(LOG_ERR, "Wrong args specified, expected 2, got %d", ac-1);
        return -1;
    }
    syslog(LOG_DEBUG, "Writing %s to %s", av[2], av[1]);

    int fd = open(av[1], O_WRONLY | O_CREAT, S_IRWXU|S_IRWXG|S_IRWXO);

    write(fd, av[2], strlen(av[2]));
    return 0;
}


