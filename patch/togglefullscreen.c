void
togglefullscreen(const Arg *arg)
{
    if (!selmon->sel)
        return;

    if (selmon->sel->fakefullscreen) {
    	selmon->sel->fakefullscreen = 0;
    	if (selmon->sel->isfullscreen) {
    		selmon->sel->isfullscreen = 0;
    	}
    }

    setfullscreen(selmon->sel, !selmon->sel->isfullscreen);
}
