function [needupdate] = callback_CellCyclePotency(src, ~, typeid)

    if nargin < 3, typeid = 1; end

    needupdate = false;
    FigureHandle = src.Parent.Parent;
    sce = guidata(FigureHandle);
    needestimate = false;

    switch typeid
        case 1
            answer = questdlg('This function assigns cell cycle phase to each cell, continue?', '');
        case 2
            answer = questdlg('This function assigns differentiation potency [PMID:33244588] to each cell, continue?', '');
    end
    if ~strcmp(answer, 'Yes'), return; end

    switch typeid
        case 1
            if isempty(sce.c_cell_cycle_tx) || all(strcmp(unique(sce.c_cell_cycle_tx), "undetermined"))
                needestimate = true;
            else
                answer1 = questdlg('Use existing cell cycle estimation or re-compute new estimation?', ...
                    '', 'Use existing', 'Re-compute', 'Cancel', 'Use existing');
                switch answer1
                    case 'Re-compute'
                        needestimate = true;
                    case 'Cancel'
                        return;
                end
            end
            if needestimate
                fw = gui.gui_waitbar;
                sce = sce.estimatecellcycle(true, 1);
                needupdate = true;
                gui.gui_waitbar(fw);
                guidata(FigureHandle, sce);
                uiwait(helpdlg('Cell cycle phase (c_cell_cycle_tx) added.', ''));
            end
            y = sce.c_cell_cycle_tx;
            fealabels = "cell_cycle";    
        case 2
            [yes, idx] = ismember('cell_potency', sce.list_cell_attributes(1:2:end));
            if ~yes
                needestimate = true;
            else
                answer1 = questdlg('Use existing differentiation potency estimation or re-compute new estimation?', ...
                    '', 'Use existing', 'Re-compute', 'Cancel', 'Use existing');
                switch answer1
                    case 'Re-compute'
                        needestimate = true;
                    case 'Cancel'
                        return;
                end
            end
            if needestimate
                speciestag = gui.i_selectspecies(2, true);
                if isempty(speciestag), return; end
                switch speciestag
                    case 'hs'
                        speciesname = 'human';
                    case 'mm'
                        speciesname = 'mouse';
                    otherwise
                        error('Unknown species.');
                end
                fw = gui.gui_waitbar;
                sce = sce.estimatepotency(speciesname);
                needupdate = true;
                [yesx, idx] = ismember('cell_potency', sce.list_cell_attributes(1:2:end));
                assert(yesx);
                gui.gui_waitbar(fw);
                guidata(FigureHandle, sce);
                % uiwait(helpdlg('Cell differentiation potency added. To see it, use View -> Cell State (Ctrl + T)...', ''));
                uiwait(helpdlg('Cell differentiation potency added.', ''));
            end
            y =  sce.list_cell_attributes{idx+1};
            fealabels = "cell_potency";
    end
    % gui.sc_uitabgrpfig_feaplot({y}, fealabels, sce.s, FigureHandle);
    if fealabels=="cell_potency"
        uiwait(helpdlg('To see the result, use View -> Cell State (Ctrl + T). Then select "cell_potency"',''));
    else
        uiwait(helpdlg('To see the result, use View -> Cell State (Ctrl + T). Then select "Cell Cycle Phase"',''));
    end
end
